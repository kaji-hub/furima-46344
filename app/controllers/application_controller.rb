class ApplicationController < ActionController::Base
  before_action :basic_auth

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      # デバッグ用（本番環境で環境変数を確認するため）
      Rails.logger.info "BASIC_AUTH_USER present: #{ENV['BASIC_AUTH_USER'].present?}"
      Rails.logger.info "BASIC_AUTH_PASSWORD present: #{ENV['BASIC_AUTH_PASSWORD'].present?}"
      
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
