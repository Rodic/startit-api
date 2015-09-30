require 'satellizer'

class V1::SessionsController < ApplicationController

  def create
    provider = SatellizerProvider.for(params)
    render json: provider.get_jwt, status: :ok
  end
end
