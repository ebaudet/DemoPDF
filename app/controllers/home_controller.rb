class HomeController < ApplicationController
  def index
  end

  def generatePdf
    form_params = params.expect(form_params: [:name, :age])
    @name = form_params[:name]
    @age = form_params[:age]

    render pdf: "file_name"
  end
end
