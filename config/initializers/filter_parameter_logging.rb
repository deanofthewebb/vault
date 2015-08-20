#Configure sensitive information which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]