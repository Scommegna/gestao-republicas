# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @republicas = current_user.republicas.order(:name)
    @primary_republica = @republicas.first
    @despesas = Despesa.where(republica: @republicas)

    month_range = Date.current.all_month
    @current_month_expenses = @despesas.where(vencimento: month_range)
    @current_month_expenses_total = @current_month_expenses.sum(:valor)
    @registered_expenses_total = @despesas.sum(:valor)
    @active_residents_count = Resident.where(republica: @republicas).active.count
    @paid_payments_total = Pagamento.where(despesa: @current_month_expenses).sum(:valor)
    @pending_payments_total = [ @current_month_expenses_total - @paid_payments_total, 0.to_d ].max
    @recent_expenses = @despesas.includes(:republica).order(vencimento: :desc, created_at: :desc).limit(5)
  end
end
