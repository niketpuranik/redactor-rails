class RedactorRails::PicturesController < ApplicationController
  before_filter :redactor_authenticate_user!

  def index
    if redactor_current_user
      @pictures = RedactorRails.picture_model.where(:assetable_id => redactor_current_user.id).desc("created_at")
    else
      @pictures = RedactorRails.picture_model.all.desc("created_at")
    end
    render :json => @pictures.to_json
  end

  def create
    @picture = RedactorRails.picture_model.new

    file = params[:file]
    @picture.data = RedactorRails::Http.normalize_param(file, request)
    if redactor_current_user
      # @picture.send("#{RedactorRails.devise_user}=", redactor_current_user)
      @picture.assetable = redactor_current_user
    end

    if @picture.save
      render :text => { :filelink => @picture.send(:url, :content) }.to_json
    else
      render json: { error: @picture.errors }
    end
  end

  private

  def redactor_authenticate_user!
    if RedactorRails.picture_model.new.has_attribute?(RedactorRails.devise_user)
      super
    end
  end
end
