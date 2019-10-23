class RelatorioPublicoController < ApplicationController
  def index
    @relatorios = Relatpublico.all

    if current_user.licenciatura == 'Ciências da Natureza'
      redirect_to action: "edit"
    end

    respond_to do |format|
     format.html
     format.pdf do
       @relatorio = Relatpublico.all

       if current_user.role == "admin"
         @usuario_matricula = params['matricula']
       else
         @usuario_matricula = current_user.matricula
       end
       @users = current_user.update(:status_impressao => true)
       pdf = PublicosPdf.new(@relatorio, current_user, @usuario_matricula)
       send_data pdf.render, filename: 'relatorio.pdf', type: 'application/pdf', disposition: 'inline'

       if current_user.role != "admin"
         ContactMailer.confirmacao_impressao(current_user).deliver
       end
     end
    end

  end

  def update
    @relatorios = current_user.update(user_params)
    redirect_to relatorio_publico_index_path, notice: 'Dados Atualizados com sucesso!'
  end

  def create
    @relatorios = Relatpublico.new(relatorio_params)

    @users = current_user.update(:pdf_publico => true)

    @relatorios.ano = '20'+@relatorios.ano
    @relatorios.matricula_aluno = current_user.matricula
    @relatorios.nome = current_user.nome
    @relatorios.licenciatura = current_user.licenciatura
    @relatorios.periodo = current_user.periodo

    if @relatorios.save
      @relatoutro = Relatpublico.last

      RelatorioOutrosMailer.contact_message(@relatoutro, current_user).deliver
      flash[:notice] = 'Mensagem enviada com sucesso'
      redirect_to estagio_welcome_index_path, id: @relatorios.id,  notice: 'Relatório salvo com sucesso!'
    else
      redirect_to estagio_welcome_index_path, notice: 'Ocorreu um erro ao salvar o relatório, tente novamente mais tarde!'
    end
  end

  def status_impressao
    current_user.status_impressao = true
  end

  def user_params
    params.permit(:licenciatura)
  end

  def relatorio_params
    params.permit(:parceria_firmada_com, :denominada_estagio, :CNPJ_estagio, :rua_estagio, :numero_estagio, :periodo_letivo, :bairro_estagio, :municipio_estagio, :telefone_estagio, :representado_por, :ano, :semestre, :endereco, :bairro, :municipio, :estado, :CEP, :periodo_de, :periodo_a)
  end
end
