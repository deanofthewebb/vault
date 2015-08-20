require 'onelogin/ruby-saml/settings'

class Account

  # should retrieve SAML-settings based on subdomain, IP-address, NameID or similar

  def Account.get_saml_settings
    settings = Onelogin::Saml::Settings.new
    if Rails.env.development?
      settings.assertion_consumer_service_url   = 'https://ghqpichefnode4.atl.careerbuilder.com/saml/consume'
      settings.issuer                           = 'https://ghqpichefnode4.atl.careerbuilder.com'
      settings.idp_sso_target_url               = 'https://cb.oktapreview.com/app/template_saml_2_0/k2qioltpQYTPWVDHDXGE/sso/saml'
      settings.idp_cert_fingerprint             = '51:D8:90:FA:D8:04:EB:5B:29:0D:97:11:94:D8:7F:95:71:EE:B2:B6'
      settings.name_identifier_format           = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
    elsif Rails.env.test?
      settings.assertion_consumer_service_url   = 'https://ghqpichefnode4.atl.careerbuilder.com/saml/consume'
      settings.issuer                           = 'https://ghqpichefnode4.atl.careerbuilder.com'
      settings.idp_sso_target_url               = 'https://cb.oktapreview.com/app/template_saml_2_0/k2qioltpQYTPWVDHDXGE/sso/saml'
      settings.idp_cert_fingerprint             = '51:D8:90:FA:D8:04:EB:5B:29:0D:97:11:94:D8:7F:95:71:EE:B2:B6'
      settings.name_identifier_format           = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
    else
      settings.assertion_consumer_service_url   = 'https://vault.careerbuilder.com/saml/consume'
      settings.issuer                           = 'https://vault.careerbuilder.com'
      settings.idp_sso_target_url               = 'https://cb.okta.com/app/template_saml_2_0/ky96rwkqSNZMJDZUQEUE/sso/saml'
      settings.idp_cert_fingerprint             = 'D4:9F:F7:9B:78:F8:B8:B7:D3:83:A2:B6:AB:FB:79:0B:5C:4B:23:C5'
      settings.name_identifier_format           = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
    end

    settings
  end


end
