# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @republicas = current_user.participating_republicas

    # Sem nenhuma república (própria ou em que participe): vai para a vitrine.
    return redirect_to explore_republicas_path if @republicas.empty?

    @republica = @republicas.find_by(id: params[:republica_id]) || @republicas.first
    @primary_republica = @republica
    @is_owner = @republica.user_id == current_user.id

    @residents = @republica.residents.active.order(:name)
    @active_residents_count = @residents.size
    @despesas = @republica.despesas

    month_range = Date.current.all_month
    @current_month_expenses = @despesas.where(vencimento: month_range)
    @current_month_expenses_total = @current_month_expenses.sum(:valor)
    @registered_expenses_total = @despesas.sum(:valor)
    @paid_payments_total = Pagamento.where(despesa: @current_month_expenses).sum(:valor)
    @pending_payments_total = [ @current_month_expenses_total - @paid_payments_total, 0.to_d ].max
    @recent_expenses = @despesas.order(vencimento: :desc, created_at: :desc).limit(5)
    @total_por_morador = total_por_morador(@despesas, @residents)
  end

  private

  # Total devido por cada morador somando a cota de todas as despesas.
  def total_por_morador(despesas, residents)
    totais = residents.each_with_object({}) { |r, h| h[r.id] = 0.to_d }
    despesas.each do |despesa|
      despesa.divisao_por_morador.each do |morador, cota|
        totais[morador.id] = totais.fetch(morador.id, 0.to_d) + cota
      end
    end
    totais
  end
end
