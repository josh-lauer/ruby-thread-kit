module ThreadKit
  class Pool
    attr_reader :lock, :size, :jobs, :workers

    def initialize(size)
      @size = size
      @jobs = Queue.new
      @lock = Monitor.new
      @workers = []
      fill_the_pool
      at_exit { shutdown }
    end

    # schedule a job to be performed
    def schedule(*args, &block)
      lock.synchronize do
        jobs << [block, args]
      end
    end

    # exit after finishing all queued jobs
    def shutdown
      size.times { exit_worker }
      workers.each(&:join)
    end

    # exit after finishing all currently-processing jobs and clear the queue
    # any queued jobs that have not yet been started will not be performed
    def exit!
      clear_jobs
      shutdown
    end

    # kill all workers immediately and stop. do not finish current jobs.
    def kill!
      workers.each(&:kill)
      clear_jobs
    end

    private

    # empty the job queue
    def clear_jobs
      jobs.clear
    end

    # populate the worker pool
    def fill_the_pool
      size.times { add_worker }
    end

    # create a worker and start it
    def add_worker
      workers << Thread.new { do_work }
    end

    # cause one worker to exit
    def exit_worker
      schedule { throw :exit }
    end

    # perform jobs until the exit signal is thrown
    def do_work
      catch(:exit) do
        loop { perform_job }
      end
    end

    # perform one job off the queue. this will sleep the thread until
    # a job is available if the queue is empty, and revive it
    def perform_job
      job, args = @jobs.pop
      job.call(*args)
    end

  end
end