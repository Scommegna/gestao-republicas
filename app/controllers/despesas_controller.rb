# frozen_string_literal: true

class DespesasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_republica
  before_action :set_despesa, only: [ :show, :edit, :update, :destroy ]

  def index
    @despesas = @republica.despesas.order(vencimento: :desc, created_at: :desc)
  end

  def show
  end

  def new
    @despesa = @republica.despesas.build
  end

  def edit
  end

  def create
    @despesa = @republica.despesas.build(despesa_params)

    if @despesa.save
      redirect_to republica_despesa_path(@republica, @despesa), notice: "Despesa cadastrada com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @despesa.update(despesa_params)
      redirect_to republica_despesa_path(@republica, @despesa), notice: "Despesa atualizada com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @despesa.destroy
    redirect_to republica_despesas_path(@republica), notice: "Despesa removida."
  end

  private

  def set_republica
    @republica = current_user.republicas.find(params[:republica_id])
  end

  def set_despesa
    @despesa = @republica.despesas.find(params[:id])
  end

  def despesa_params
    params.require(:despesa).permit(:descricao, :valor, :vencimento, :categoria)
  end
end
