# frozen_string_literal: true

class Pagamento < ApplicationRecord
  belongs_to :resident
  belongs_to :despesa

  enum :status, { pending: "pending", paid: "paid" }

  attr_accessor :skip_validation

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data_pagamento, :status, presence: true
  validate :resident_and_despesa_belong_to_same_republica
  validate :valor_does_not_exceed_resident_share, unless: :skip_validation?
  validate :paid_status_requires_full_expense_share, unless: :skip_validation?

  def valor_devido
    despesa.valor_por_morador || 0.to_d
  end

  def total_registrado_para_despesa
    self.class.where(resident: resident, despesa: despesa).where.not(id: id).sum(:valor) + valor.to_d
  end

  private

  def skip_validation?
    skip_validation == true
  end

  def resident_and_despesa_belong_to_same_republica
    return if resident.blank? || despesa.blank?
    return if resident.republica_id == despesa.republica_id

    errors.add(:resident, "deve pertencer à mesma república da despesa")
  end

  def valor_does_not_exceed_resident_share
    return if resident.blank? || despesa.blank? || valor.blank?
    return if total_registrado_para_despesa <= valor_devido

    errors.add(:valor, "não pode ultrapassar o valor devido pelo morador")
  end

  def paid_status_requires_full_expense_share
    return unless paid?
    return if resident.blank? || despesa.blank? || valor.blank?
    return if total_registrado_para_despesa >= valor_devido

    errors.add(:status, "só pode ser pago quando o valor total da cota for registrado")
  end
end
