# frozen_string_literal: true

class PagamentosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_republica
  before_action :set_period
  before_action :set_pagamento, only: :update

  def index
    load_payment_data
    @pagamento = Pagamento.new(data_pagamento: Date.current, status: :paid)
  end

  def create
    @pagamento = Pagamento.new(pagamento_params)
    @pagamento.resident = @republica.residents.find(pagamento_params[:resident_id])
    @pagamento.despesa = @republica.despesas.find(pagamento_params[:despesa_id])

    if @pagamento.save
      redirect_to republica_pagamentos_path(@republica, month: @pagamento.despesa.vencimento.month, year: @pagamento.despesa.vencimento.year),
                  notice: "Pagamento registrado com sucesso."
    else
      load_payment_data
      render :index, status: :unprocessable_content
    end
  end

  def update
    if @pagamento.update(pagamento_update_params)
      redirect_to republica_pagamentos_path(@republica, month: @pagamento.despesa.vencimento.month, year: @pagamento.despesa.vencimento.year),
                  notice: "Status do pagamento atualizado."
    else
      load_payment_data
      render :index, status: :unprocessable_content
    end
  end

  private

  def set_republica
    @republica = current_user.republicas.find(params[:republica_id])
  end

  def set_period
    @month = params.fetch(:month, Date.current.month).to_i
    @year = params.fetch(:year, Date.current.year).to_i
    @period = Date.new(@year, @month, 1).all_month
  rescue Date::Error
    @month = Date.current.month
    @year = Date.current.year
    @period = Date.current.all_month
  end

  def set_pagamento
    @pagamento = Pagamento.joins(:resident).where(residents: { republica_id: @republica.id }).find(params[:id])
  end

  def load_payment_data
    @residents = @republica.residents.active.order(:name)
    @despesas = @republica.despesas.where(vencimento: @period).order(:vencimento, :descricao)
    @pagamentos = Pagamento.includes(:resident, :despesa).where(resident: @residents, despesa: @despesas).order(data_pagamento: :desc, created_at: :desc)

    @payment_rows = @residents.map do |resident|
      devido = @despesas.sum { |despesa| despesa.valor_por_morador || 0.to_d }
      pago = @pagamentos.select { |pagamento| pagamento.resident_id == resident.id }.sum(&:valor)
      pendente = [ devido - pago, 0.to_d ].max

      {
        resident: resident,
        devido: devido,
        pago: pago,
        pendente: pendente,
        status: devido.positive? && pendente.zero? ? "paid" : "pending"
      }
    end

    @total_due = @payment_rows.sum { |row| row[:devido] }
    @total_paid = @payment_rows.sum { |row| row[:pago] }
    @total_pending = @payment_rows.sum { |row| row[:pendente] }
  end

  def pagamento_params
    params.require(:pagamento).permit(:resident_id, :despesa_id, :valor, :data_pagamento, :status)
  end

  def pagamento_update_params
    params.require(:pagamento).permit(:valor, :data_pagamento, :status)
  end
end
