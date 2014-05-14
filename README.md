# Network::Monitor

`Network::Monitor` is a simple script to measure network utilisation and error rates on SNMP capable network hardware.

**This is an old project which I've migrated to a gem. It probably needs a lot more work**

## Installation

Install it yourself as:

    $ gem install network-monitor

## Usage

Create a `hosts.conf` file which includes all the IP addresses of your networking hardware, e.g. switches, wireless routers, etc:

	  - '10.0.0.1'
	  - '10.0.0.10'
	  - '10.0.0.30'
	  - '10.0.0.31'
	  - '10.0.0.32'

Then run `network-monitor`:

	$ network-monitor --hosts path/to/hosts.conf
	                   Utilization Report @ 2014-05-14 20:28:38 +1200                   
	                                  Errors Detected                                   
	           10.0.0.10:    2      IN#      57 OUT#       0
	           10.0.0.10:    3      IN#      32 OUT#       0
	           10.0.0.30:    2      IN#     847 OUT#       0
	           10.0.0.32:    2      IN#     120 OUT#       0
	                              17 ports not displayed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2014, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
