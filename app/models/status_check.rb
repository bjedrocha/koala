class StatusCheck

  def self.get_stats
    info = Resque.info
    workers = Resque.working
    jobs = workers.collect {|w| w.job }
    worker_jobs = workers.zip(jobs)
    worker_jobs = worker_jobs.reject { |w, j| w.idle? }
    last_failed = Resque::Failure.all(0, 100).sort {|x,y| y["failed_at"] <=> x["failed_at"] }.first

    if last_failed.nil?
      last_failed_date = "N/A"
      last_failed_time = "N/A"
      last_failed_queue = "N/A"
    else
      last_failed_datetime = DateTime.parse(last_failed["failed_at"])
      last_failed_date = last_failed_datetime.today? ? "Today" : last_failed_datetime.strftime("%b %d, %Y")
      last_failed_time = last_failed_datetime.strftime("%l:%M:%S %p").lstrip
      last_failed_queue = last_failed["queue"]
    end

    # return it
    {
      :overview => {
        :number_of_workers => Resque.workers.size,
        :number_working => worker_jobs.size
      },
      :stats => {
        :processed => info[:processed],
        :pending => info[:pending],
        :failed => info[:failed]
      },
      :recent_failures => {
        :date => last_failed_date,
        :time => last_failed_time,
        :queue => last_failed_queue
      }
    }
  end
end