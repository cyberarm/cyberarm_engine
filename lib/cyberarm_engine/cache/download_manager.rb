module CyberarmEngine
  module Cache
    class DownloadManager
      attr_reader :downloads

      def initialize(max_parallel_downloads: 4)
        @max_parallel_downloads = max_parallel_downloads
        @downloads = []
      end

      def download(url:, save_as: nil, &callback)
        uri = URI(url)
        save_as ||= "filename_path" # TODO: if no save_as path is provided, then get one from the Cache controller

        @downloads << Download.new(uri: uri, save_as: save_as, callback: callback)
      end

      def status
        if active_downloads > 0
          :busy
        else
          :idle
        end
      end

      def progress
        remaining_bytes = @downloads.map { |d| d.remaining_bytes }.sum
        total_bytes = @downloads.map { |d| d.total_bytes }.sum

        v = 1.0 - (remaining_bytes.to_f / total_bytes)
        return 0.0 if v.nan?

        v
      end

      def active_downloads
        @downloads.select { |d| %i[pending downloading].include?(d.status) }
      end

      def update
        @downloads.each do |download|
          if download.status == :pending && active_downloads.size <= @max_parallel_downloads
            download.status = :downloading
            Thread.start { download.download }
          end
        end
      end

      def prune
        @downloads.delete_if { |d| d.status == :finished || d.status == :failed }
      end

      class Download
        attr_accessor :status
        attr_reader :uri, :save_as, :callback, :remaining_bytes, :total_downloaded_bytes, :total_bytes,
                    :error_message, :started_at, :finished_at

        def initialize(uri:, save_as:, callback: nil)
          @uri = uri
          @save_as = save_as
          @callback = callback

          @status = :pending

          @remaining_bytes = 0.0
          @total_downloaded_bytes = 0.0
          @total_bytes = 0.0

          @error_message = ""
        end

        def progress
          v = 1.0 - (@remaining_bytes.to_f / total_bytes)
          return 0.0 if v.nan?

          v
        end

        def download
          @status = :downloading
          @started_at = Time.now # TODO: monotonic time

          io = File.open(@save_as, "w")
          streamer = lambda do |chunk, remaining_bytes, total_bytes|
            io.write(chunk)

            @remaining_bytes = remaining_bytes.to_f
            @total_downloaded_bytes += chunk.size
            @total_bytes = total_bytes.to_f
          end

          begin
            response = Excon.get(
              @uri.to_s,
              middlewares: Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower],
              response_block: streamer
            )

            if response.status == 200
              @status = :finished
              @finished_at = Time.now # TODO: monotonic time
              @callback.call(self) if @callback
            else
              @error_message = "Got a non 200 HTTP status of #{response.status}"
              @status = :failed
              @finished_at = Time.now # TODO: monotonic time
              @callback.call(self) if @callback
            end
          rescue StandardError => e # TODO: cherrypick errors to cature
            @status = :failed
            @finished_at = Time.now # TODO: monotonic time
            @error_message = e.message
            @callback.call(self) if @callback
          end
        ensure
          io.close if io
        end
      end
    end
  end
end
