class PayPhonesController < ApplicationController
  before_action :set_pay_phone, only: [:show, :edit, :update, :destroy]

  # GET /pay_phones
  def index
    @pay_phones = PayPhone.all
  end

  # GET /pay_phones/1
  def show
  end

  # GET /pay_phones/new
  def new
    @pay_phone = PayPhone.new
  end

  # GET /pay_phones/1/edit
  def edit
  end

  # POST /pay_phones
  def create
    @pay_phone = PayPhone.new(pay_phone_params)

    if @pay_phone.save
      redirect_to @pay_phone, notice: 'Pay phone was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /pay_phones/1
  def update
    if @pay_phone.update(pay_phone_params)
      redirect_to @pay_phone, notice: 'Pay phone was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /pay_phones/1
  def destroy
    @pay_phone.destroy
    redirect_to pay_phones_url, notice: 'Pay phone was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pay_phone
      @pay_phone = PayPhone.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pay_phone_params
      params.require(:pay_phone).permit(:number, :neighborhood, :lat, :lon)
    end
end
