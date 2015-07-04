require 'thread_kit/version'

module ThreadKit
  module ThreadLocal
    autoload :Store, 'thread_kit/thread_local/store'
    autoload :Accessors, 'thread_kit/thread_local/accessors'
  end
  autoload :Pool, 'thread_kit/pool'
end
