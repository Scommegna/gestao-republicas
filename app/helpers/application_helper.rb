module ApplicationHelper
  TIPO_BADGE = {
    "feminina" => { css: "text-bg-danger", icon: "bi-gender-female" },
    "masculina" => { css: "text-bg-primary", icon: "bi-gender-male" },
    "mista" => { css: "text-bg-secondary", icon: "bi-gender-ambiguous" }
  }.freeze

  # Selo visual para o tipo de uma república (feminina/masculina/mista).
  def tipo_badge(republica)
    config = TIPO_BADGE.fetch(republica.tipo, TIPO_BADGE["mista"])
    tag.span(class: "badge rounded-pill #{config[:css]}") do
      concat tag.i("", class: "bi #{config[:icon]} me-1", aria: { hidden: true })
      concat republica.tipo_label
    end
  end
end
