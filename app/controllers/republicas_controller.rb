class RepublicasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_republica, only: [ :show, :edit, :update, :destroy ]

  def index
    @republicas = current_user.republicas.order(:name)
  end

  def show
  end

  def new
    @republica = current_user.republicas.build
  end

  def edit
  end

  def create
    @republica = current_user.republicas.build(republica_params)

    if @republica.save
      redirect_to @republica, notice: "República criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @republica.update(republica_params)
      redirect_to @republica, notice: "República atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @republica.destroy
    redirect_to republicas_url, notice: "República removida."
  end

  private

  def set_republica
    @republica = current_user.republicas.find(params[:id])
  end

  def republica_params
    params.require(:republica).permit(:name, :endereco, :descricao)
  end
end
