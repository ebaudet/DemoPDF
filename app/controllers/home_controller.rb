class HomeController < ApplicationController
  def index
  end

  def generatePdf
    @name = params[:form_params][:name]
    @age = params[:form_params][:age]
  end
end
