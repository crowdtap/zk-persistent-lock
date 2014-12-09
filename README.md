ZK Persistent Lock [![Build Status](https://travis-ci.org/crowdtap/zk-persistent-lock.png?branch=master)](https://travis-ci.org/crowdtap/zk-persistent-lock)
======

This is a lock built using Zookeeper that ensures that only one process can access a
critical section of code.

This was built as the ZK gem only supports ephermal locks.

Install
-------

```ruby
gem install zk-persistent-lock
```
or add the following line to your Gemfile:
```ruby
gem 'zk-persistent-lock'
```
and run `bundle install`

Usage
-----

```ruby
  lock = ZK::PersistentLock.new('lock_name')
  lock.lock do
    # Critical section
  end

  # Extend the lock by the timeout value. This will work regardless of whether
  # the lock has timed out or not.
  if lock.extend
    # The lock was successfully extended
  else
    # The lock was not successfully extended. This means that the lock was taken by
    # another process.
  end
```

Advanced
--------

The following options can be passed into the lock method (default values are
listed):

```ruby
  ZK::PersistentLock.new('lock_name', :hosts     => 'localhost:2181',
                                      :timeout   => 60, # seconds
                                      :expire    => 60, # seconds
                                      :sleep     => 0.1, # seconds
                                      :namespace => 'zk-persistent-lock')
```

If the lock has expired within the specified `:expire` value then the lock method
will return `:recovered`, otherwise it will return `true` if it has been acquired
or `false` if it could not be acquired within the specified `:timeout` value.

Note that if a lock is recovered there is no guarantee that the other process
has died vs. that it is a slow running process. Therefore be very mindful of what
expiration value you set as a value too low can result in multiple processes
accessing the critical section. If you have recovered a lock you should cleanup
for the dead process if its possible to get into an unstable state.


Requirements
------------
* Zookeeper 3.4.x


License
-------
Copyright (C) 2013 Crowdtap

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
