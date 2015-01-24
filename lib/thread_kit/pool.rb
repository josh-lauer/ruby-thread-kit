module ThreadKit
  class Pool
    attr_reader :size, :jobs, :workers

    def initialize(size)
      @size = size
      @jobs = Queue.new
      @workers = []
      fill_the_pool
      at_exit { shutdown }
    end

    # schedule a job to be performed
    def schedule(*args, &block)
      jobs << [block, args]
    end

    # bail after finishing remaining jobs
    def shutdown
      size.times { exit_worker }
      workers.map(&:join)
    end

    # bail without finishing remaining jobs
    def shutdown!
      jobs.clear
      shutdown
    end

    private begin

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

      # dequeue and perform a single job
      def perform_job
        job, args = @jobs.pop
        job.call(*args)
      end

    end

  end
end