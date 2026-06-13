# frozen_string_literal: true

FactoryBot.define do
  factory :pagamento do
    resident
    despesa { association(:despesa, republica: resident.republica) }
    valor { 100.0 }
    data_pagamento { Date.current }
    status { "pending" }
  end
end
