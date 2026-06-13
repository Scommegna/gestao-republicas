# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @republicas = current_user.republicas.order(:name)
    @primary_republica = @republicas.first
    @despesas = Despesa.where(republica: @republicas)

    month_range = Date.current.all_month
    @current_month_expenses_total = @despesas.where(vencimento: month_range).sum(:valor)
    @registered_expenses_total = @despesas.sum(:valor)
    @active_residents_count = Resident.where(republica: @republicas).active.count

    # There is no payment table yet; use expense due dates as the current payment signal.
    @pending_payments_count = @despesas.where(vencimento: Date.current..).count
    @paid_payments_count = @despesas.where(vencimento: ...Date.current).count
    @recent_expenses = @despesas.includes(:republica).order(vencimento: :desc, created_at: :desc).limit(5)
  end
end
