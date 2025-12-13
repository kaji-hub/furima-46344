# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  # PAY.JPのスクリプトを許可
  policy.script_src  :self, :https, "https://js.pay.jp"
  policy.style_src   :self, :https
  # PAY.JPのAPIへの接続を許可
  policy.connect_src :self, :https, "https://api.pay.jp"
  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# Generate session nonces for permitted importmap, inline scripts, and inline styles.
Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)

# Report violations without enforcing the policy (開発環境のみ)
if Rails.env.development?
  Rails.application.config.content_security_policy_report_only = true
end
