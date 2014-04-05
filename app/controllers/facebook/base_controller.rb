class Facebook::BaseController < ApplicationController
  skip_before_filter :staging_mode_authenticate
end
