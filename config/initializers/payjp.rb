if Rails.env.development?
  # macOSでのSSL証明書パスを設定
  ENV['SSL_CERT_FILE'] ||= '/etc/ssl/cert.pem'
  
  # rest-clientのSSL検証をスキップ
  require 'rest-client'
  module RestClient
    class Request
      orig_initialize = instance_method(:initialize)
      define_method(:initialize) do |args|
        args[:verify_ssl] = false
        orig_initialize.bind(self).call(args)
      end
    end
  end
end

