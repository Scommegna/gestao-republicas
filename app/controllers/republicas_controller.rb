class RepublicasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_republica, only: [ :show, :edit, :update, :destroy ]

  def index
    @republicas = current_user.republicas.order(:name)
  end

  # Vitrine de todas as repúblicas, com busca, para o usuário encontrar e entrar.
  def explore
    @republicas = Republica.includes(:residents).order(:name)

    if params[:q].present?
      term = "%#{params[:q].strip}%"
      @republicas = @republicas.where("name LIKE :q OR endereco LIKE :q", q: term)
    end

    @participating_ids = current_user.republica_ids | current_user.member_republica_ids
  end

  # Entrar em uma república como morador (membro).
  def join
    republica = Republica.find(params[:id])

    if current_user.participating?(republica)
      return redirect_to dashboard_path, notice: "Você já participa desta república."
    end

    resident = republica.residents.build(
      user: current_user,
      name: "#{current_user.first_name} #{current_user.last_name}".strip,
      email: current_user.email,
      active: true
    )

    if resident.save
      redirect_to dashboard_path(republica_id: republica.id), notice: "Bem-vindo(a) à #{republica.name}!"
    else
      redirect_to explore_republicas_path, alert: resident.errors.full_messages.to_sentence
    end
  end

  # Sair de uma república em que o usuário participa como membro.
  def leave
    republica = Republica.find(params[:id])
    current_user.resident_profiles.find_by(republica: republica)&.destroy
    redirect_to explore_republicas_path, notice: "Você saiu da #{republica.name}."
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
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @republica.update(republica_params)
      redirect_to @republica, notice: "República atualizada com sucesso."
    else
      render :edit, status: :unprocessable_content
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
    params.require(:republica).permit(:name, :endereco, :descricao, :tipo)
  end
end
