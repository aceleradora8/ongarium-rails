require 'rails_helper'

describe NgosController, type: :controller do
  describe '#index' do
    before :each do
      @address = Address.create!(city:"POA", zipcode: "5", address:"rua")
      @cause = Cause.create!(name: "Animais")
      user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken10", role:"ngo")
      user2 = User.create!(email:"tw@tw.com", password:"123321", confirmed: true, auth_token: "esseehmeutoken1", role:"ngo")
      user3 = User.create!(email:"twe321@tw.com", password:"123321", confirmed: true, auth_token: "esseehmeutoken4", role:"ngo")
      usernotconfirmed = User.create!(email:"twu321@tw.com", password:"1323321", confirmed: false, auth_token: "esseehmeutoken2", role:"ngo")
      @ngo = Ngo.create!(address_id: @address.id, phone1: "1234", name:"nome1", description: "Qualquer coisa1",user_id:user.id)
      @ngo.causes.push(@cause)
      @ngo2 = Ngo.create!(address_id: @address.id, phone1: "1234", name:"nome2", description: "Qualquer coisa2",user_id:user2.id)
      @ngonotconfirmed = Ngo.create!(address_id: @address.id, phone1: "1234", name:"nome2123", description: "Qualquer coisa2",user_id:usernotconfirmed.id)
      user_new = User.new(email:"new@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo_new = Ngo.new(address_id: @address.id, phone1: "1234", name:"nome_new", description: "Qualquer coisa",user:user_new)
      @ngo_private = Ngo.create!(address_id: @address.id, phone1: "1234", name: "qualquer ai", description: "brbrbr", user_id:user3.id, privacy: true)
      @controller = NgosController.new
    end

    it 'show all results when index' do
      get :index
      expect(assigns[:ngos_result]).to match_array([@ngo, @ngo2, @ngo_private])
    end

    it 'return ngo when search by name' do
      get :index, text_search: ''
      expect(assigns[:ngos_search]).to match_array([@ngo, @ngo2, @ngo_private])
    end

    it 'return all ngos from POA when passed by text_search' do
      get :index, text_search: 'nome1'
      expect(assigns[:ngos_search]).to match_array([@ngo])
    end

    it 'return all ngos from POA when passed by params city' do
      get :index, text_search: '', city: 'POA'
      expect(assigns[:ngos_search]).to match_array([@ngo, @ngo2, @ngo_private])
    end

    it 'return a specific NGO when name passed by params with city' do
      get :index, text_search: 'nome1', city: 'POA'
      expect(assigns[:ngos_search]).to match_array([@ngo])
    end

    it 'return ngo filtered by city' do
      xhr :get, :index, {cities: [@address.city]}
      expect(assigns[:ngos_result]).to match_array([@ngo, @ngo2, @ngo_private])
    end

    it 'return ngo filtered by causes' do
      xhr :get, :index, {causes: [@cause.id]}
      expect(assigns[:ngos_result]).to match_array([@ngo])
    end

    it 'return ngo filtered by causes and cities' do
      xhr :get, :index, {causes: [@cause.id], cities: [@address.city]}
      expect(assigns[:ngos_result]).to match_array([@ngo])
    end

    it 'expect ngos result be equals a search when params = nil' do
      get :index, text_search: ''
      expect(assigns[:ngos_result]).to eq(assigns[:ngos_search])
    end

    it 'expect redirect to 404 if ngo isnt present' do
      get :show, id: -20
      expect(response).to redirect_to('/404')
    end

    it 'returns true when passing a ngos existing name' do
      expect(@controller.ngo_exists?(@ngo)).to be true
    end

    it 'returns true when passing a ngos existing email' do
      expect(@controller.ngo_exists?(@ngo)).to be true
    end

    it 'returns false when a new ngo is passed' do
      expect(@controller.ngo_exists?(@ngo_new)).to be false
    end

    it 'returns false when ngo was deleted' do
      @ngo.user.email = nil
      @ngo.user.role = nil
      @ngo.destroy
      expect(@controller.ngo_exists?(@ngo)).to be false
    end
  end

    describe '#create' do
      before :each do
        address = Address.create!(city:"POA", zipcode: "5", address:"rua")
        user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
        user2 = User.create!(email:"tw@tw.com", password:"123321", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
        @ngo = Ngo.create!(address_id: address.id, phone1: "1234", name:"nome1", description: "Qualquer coisa1",user_id:user.id)
        @ngo2 = Ngo.create!(address_id: address.id, phone1: "1234", name:"nome2", description: "Qualquer coisa2",user_id:user2.id)
      end

    it 'return success if NGO was created' do
      post :create, {ngo:
        {
        name:"ABC",
        description:"Abobora",
        privacy: true,
        phone1: "1234",
        address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado" },
        user_attributes: {email:"abc@pop.com", password: "123", password_confirmation: "123"}
        }
      }
        expect(flash[:notice]).to eq("Organização cadastrada com sucesso! Foi enviado um e-mail de confirmação, verifique sua caixa de entrada.")
    end

    it 'return error if ngo name already is on use' do
      post :create, {ngo: {
        name:"nome1",
        description:"Qualquer coisa1",
        privacy: true,
        phone1: "1234",
        address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado" },
        user_attributes: {email:"abc@pop.com", password: "123", password_confirmation: "123"}
        }
      }
      expect(assigns(:error_message)).to eq("Já existe uma organização cadastrada com este nome.")
    end

    it 'return error if ngo email already is on use' do
      post :create, {ngo: {
        name:"nome13213",
        description:"Qualquer coisa1",
        privacy: true,
        address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado" },
        user_attributes: {email:"teste@teste.com", password: "123", password_confirmation: "123"},
        phones_attributes: {"1"=>{phone_number:"123456789"} }
        }
      }
      expect(assigns(:error_message)).to eq("E-mail já cadastrado!")
    end

      it 'render new if anything goes wrong' do
      post :create, {ngo: {
        name: nil,
        description:"Qualquer coisa1",
        privacy: true,
        phone1: "1234",
        address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado" },
        user_attributes: {email:"abc@pop.com", password: "123", password_confirmation: "123"}
        }
      }
      expect(response).to render_template("new")
    end
  end

  describe '#edit' do
    before :each do
      address = Address.create!(city:"POA", zipcode: "5", address:"rua")
      @user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      user2 = User.create!(email:"tw@tw.com", password:"123321", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo = Ngo.create!(address_id: address.id, phone1: "1234", name:"nome", description: "Qualquer coisa",user_id:@user.id)
    end

    it 'finds ngo when ID is correct' do
      cookies[:auth_token] = @ngo.user.auth_token
      get :edit, id: @ngo.id
      expect(assigns(:ngo)).to eq(@ngo)
    end
  end

  describe '#update' do
    before :each do
      address = Address.create!(city:"POA", zipcode: "5", address:"rua")
      @user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo = Ngo.create!(address_id: address.id, phone1: "1234", name:"nome", description: "Qualquer coisa",user_id:@user.id)
      user_new = User.new(email:"new@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo_new = Ngo.new(address_id: address.id, phone1: "1234", name:"nome_new", description: "Qualquer coisa",user:user_new)
    end

    it 'return success when ngo is updated' do
      put :update,
      {
        id: @ngo.id, ngo:
        {
          name:"Organização atualizada", description:"ae", privacy:false,
          address_attributes: {address:"end atualizado", zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado"}
        }
      }
      expect(flash[:notice]).to eq("Informações atualizadas com sucesso!")
    end

    it 'render edit if fails and show "Error" on notice' do
      put :update,
      {
        id: @ngo.id, ngo:
        {
          name: nil, description:"ae", privacy:false,
          address_attributes: {zipcode:"66666-333", complement:"atualizado", state:"UP", city:"Atual", country:"Brasil", neighborhood:"Atualizado"}
        }
      }
      expect(response).to render_template('edit')
    end
  end

  describe '#destroy' do
    before :each do
      address = Address.create!(city:"POA", zipcode: "5", address:"rua")
      @user = User.create!(email:"teste@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo = Ngo.create!(address_id: address.id, phone1: "1234", name:"nome", description: "Qualquer coisa",user_id:@user.id)
      user_new = User.new(email:"new@teste.com", password:"123", confirmed: true, auth_token: "esseehmeutoken", role:"ngo")
      @ngo_new = Ngo.new(address_id: address.id, phone1: "1234", name:"nome_new", description: "Qualquer coisa",user:user_new)
    end

     it 'return success when the NGO was deleted' do
       cookies[:auth_token] = @ngo.user.auth_token
       delete :destroy, id: @ngo.id, password:"123"
       expect(flash[:notice]).to eq("A organização foi removida com sucesso!")
     end

     it 'return failure message when the NGO password is wrong' do
       cookies[:auth_token] = @ngo.user.auth_token
       delete :destroy, id: @ngo.id, password:"4321"
       expect(flash[:error]).to eq("Senha incorreta")
     end
  end

  describe '#new' do
    it 'expect ngo be a instance of Ngo' do
      get :new
      expect(assigns(:ngo)).to be_a_new(Ngo)
    end
  end
end
