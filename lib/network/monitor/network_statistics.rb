
require 'rubygems'
gem 'snmp'

require 'snmp'
require 'active_record'

Counter32Max = 4294967295

OPTIONS = {
  :PostLog => true,
  :Duration => 10,
  :DatabaseFile => "ports.db",
  :HostsFile => "hosts.conf"
}

class Float
  def to_prs
    return sprintf("%0.2f\%", self * 100.0)
  end
end

def bits_to_string(size)
  human_size = size
  levels = 0
  
  while human_size >= 1000
    human_size /= 1000.0
    levels += 1
  end
  
  #maybe localize this?    
  sprintf("%0.1f%s", human_size, ['', 'K', 'M', 'G', 'T', 'X'].fetch(levels)) + 'b'
end

ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database  => OPTIONS[:DatabaseFile]
)

unless File.exists? OPTIONS[:DatabaseFile]
  puts "Building new database..."
  
  ActiveRecord::Schema.define(:version => 1) do
    create_table :interfaces do |t|
      t.string :host, :null => false
      t.integer :ifIndex, :null => false

      t.integer :ifSpeed, :null => false

      t.integer :ifInOctets, :null => false
      t.integer :ifOutOctets, :null => false

      t.integer :ifInErrors, :null => false
      t.integer :ifOutErrors, :null => false

      t.datetime :created_at
    end
    
    change_table :interfaces do |t|
      t.index :host
      t.index :ifIndex
#      t.index :created_at
    end
  end
end

Counters = ["ifInOctets", "ifInErrors", :ifInUtilization, "ifOutOctets", "ifOutErrors", :ifOutUtilization]

$names = {}

def fetch_names(hosts)
  puts "Fetching names..."
  hosts.each do |h|
    SNMP::Manager.open(:Host => h, :Version => :SNMPv1) do |manager|
      response = manager.get(["sysDescr.0", "sysName.0"])
      
      name = response.varbind_list[1].value.to_s + ' (' + response.varbind_list[0].value.to_s + ')'
      
      $names[h] = name
    end
  end
  puts "Done."
end

class Interface < ActiveRecord::Base
  QueryColumns = ["ifIndex", "ifSpeed", "ifInOctets", "ifInErrors", "ifOutOctets", "ifOutErrors"]
  
  def self.hosts
    Interface.all.group("host").collect { |r| r.host }
  end
  
  def self.query(host)
    SNMP::Manager.open(:Host => host, :Version => :SNMPv1) do |manager|
      manager.walk(QueryColumns) do |row|
        next if row[1].value.to_i == 0 # Speed of interface is reported as 0 by some faulty equipment, ignore these ports.
        
        record = Interface.new(:host => host)
        
        QueryColumns.each_with_index do |c,i|
           record.send("#{c}=", row[i].value.to_i)
        end
        
        record.save!
      end
    end
  end
  
  def statistics(prev)
    dt = (created_at - prev.created_at).to_f
    s = {
      :startTime => prev.created_at,
      :endTime => created_at,
      :timePeriod => created_at - prev.created_at,
      :ifInOctets => ifInOctets - prev.ifInOctets,
      :ifOutOctets => ifOutOctets - prev.ifOutOctets,
      :ifInErrors => ifInErrors - prev.ifInErrors,
      :ifOutErrors => ifOutErrors - prev.ifOutErrors
    }
    
    # Counter32 may wrap and produce strange results unless we deal with it..
    [:ifInOctets, :ifOutOctets, :ifInErrors, :ifOutErrors].each do |c|
      if s[c] < 0
        s[c] = Counter32Max + s[c]
      end
    end
    
    s[:ifInUsage] = (s[:ifInOctets].to_f * 8.0) / (ifSpeed.to_f * dt)
    s[:ifOutUsage] = (s[:ifOutOctets].to_f * 8.0) / (ifSpeed.to_f * dt)
    
    return s
  end
  
  def speed_string
    bits_to_string(ifSpeed.to_i)
  end
  
  def previous
    Interface.where("host = ? and ifIndex = ? and id < ?", host, ifIndex, id).limit(1).order("created_at desc").first
  end
  
  def self.print_statistics(out, min = 0.01)
    unused_count = 0
    
    error_interfaces = []
    
    out.puts "Utilization Report @ #{Time.now.to_s}".center(84)
    Interface.all.group("host, ifIndex").each do |iface|
      r2, r1 = Interface.where("host = ? and ifIndex = ?", iface.host, iface.ifIndex).limit(2).order("created_at desc").to_a
      
      next if r1 == nil or r2 == nil

      unused = true
      name = $names[iface.host] || iface.host

      s = r2.statistics(r1)
      
      if s[:ifInErrors] > 0 or s[:ifOutErrors] > 0
        error_interfaces << [iface, name, s]
        unused = false
      end
      
      if s[:ifInUsage] > min or s[:ifOutUsage] > min
        out.print "#{name.rjust(20)}: #{iface.ifIndex.to_s.rjust(4)}    "

        [[:ifInUsage, "IN%"], [:ifOutUsage, "OUT%"]].each do |v|
          key, name = *v
          
          out.print name.rjust(8)
          out.print s[key].to_prs.rjust(8)
        end
        out.puts r1.speed_string.rjust(10)
        
        unused = false
      end
      
      unused_count += 1 if unused
    end
    
    if error_interfaces.size > 0
      out.puts "Errors Detected".center(84)
      error_interfaces.each do |r|
        iface, name, s = r
        
        out.print "#{name.rjust(20)}: #{iface.ifIndex.to_s.rjust(4)}    "
        
        [[:ifInErrors, "IN\#"], [:ifOutErrors, "OUT\#"]].each do |v|
          key, name = v
          
          out.print name.rjust(5)
          out.print s[key].to_s.rjust(8)
        end
        
        out.puts
      end
    end
    
    out.puts "#{unused_count} ports not displayed.".center(84)
  end
end