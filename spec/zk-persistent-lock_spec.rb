require 'spec_helper'

describe ZK::PersistentLock do
  subject       { ZK::PersistentLock.new(key, options) }
  let(:key)     { 'key' }

  before { subject.delete! }

  context 'when the timeout is less then the expiration' do
    let(:options) { { :timeout => 1, :expire => 1.5 } }

    it "can lock and unlock" do
      subject.lock

      subject.try_lock.should == false

      subject.unlock.should == true

      subject.try_lock.should == true
    end

    it "can lock with a block" do
      subject.lock do
        subject.try_lock.should == false
      end
      subject.try_lock.should == true
    end

    it "does not run the critical section if the lock times out" do
      subject.lock

      critical = false

      subject.lock { critical = true }.should == false

      critical.should == false
    end

    it "ensures that the lock is unlocked when locking with a block" do
      begin
        subject.lock do
          raise "An error"
        end
      rescue
      end

      subject.try_lock.should == true
    end

    it "blocks if a lock is taken for the duration of the timeout" do
      subject.lock
      unlocked = false

      Thread.new { subject.lock; unlocked = true }

      unlocked.should == false

      sleep 2

      unlocked.should == true
    end

    it "expires the lock after the lock timeout" do
      subject.lock

      subject.try_lock.should == false
      sleep 2

      subject.try_lock.should == :recovered
    end

    it "can extend the lock" do
      subject.lock

      subject.try_lock.should == false

      sleep 2
      subject.extend.should == true

      subject.try_lock.should == false
    end

    it "will not extend the lock if taken by another instance" do
      subject.lock

      subject.try_lock.should == false

      sleep 2
      ZK::PersistentLock.new(key, options).extend.should == false

      subject.try_lock.should == :recovered
    end
  end

  context 'when the expiration time is less then the timeout' do
    let(:options) { { :timeout => 2, :expire => 1 } }

    it "recovers the lock" do
      subject.lock

      critical = false

      subject.lock { critical = true }.should == :recovered

      critical.should == true
    end
  end
end
