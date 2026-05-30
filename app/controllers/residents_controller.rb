class ResidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_republica
  before_action :set_resident, only: [ :edit, :update, :destroy ]

  def index
    @residents = @republica.residents.order(:name)
  end

  def new
    @resident = @republica.residents.build
  end

  def edit
  end

  def create
    @resident = @republica.residents.build(resident_params)

    if @resident.save
      redirect_to republica_residents_path(@republica), notice: "Morador cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @resident.update(resident_params)
      redirect_to republica_residents_path(@republica), notice: "Morador atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resident.destroy
    redirect_to republica_residents_path(@republica), notice: "Morador removido."
  end

  private

  def set_republica
    @republica = current_user.republicas.find(params[:republica_id])
  end

  def set_resident
    @resident = @republica.residents.find(params[:id])
  end

  def resident_params
    params.require(:resident).permit(:name, :email, :phone)
  end
end
