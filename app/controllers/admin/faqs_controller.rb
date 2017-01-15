class Admin::FaqsController < Admin::BaseController
  before_action :fetch_faq, only: [:show, :edit, :update, :destroy]

  # GET /admin/faqs
  def index
    @faqs = Faq.order(priority: :desc).all
  end

  # GET /admin/faqs/:id
  def show; end

  # GET /admin/faqs/new
  def new
    @faq = Faq.new
  end

  # GET /admin/faqs/:id/edit
  def edit; end

  # POST /admin/faqs
  def create
    @faq = Faq.new(fetch_params)
    if @faq.save
      flash[:success] = 'FAQ created successfuly'
      redirect_to admin_faqs_path
    else
      flash[:error] = 'FAQ not created'
      render :new
    end
  end

  # PUT/PATCH /admin/faqs/:id/update
  def update
    if @faq.update_attributes(fetch_params)
      flash[:success] = 'FAQ updated successfuly'
      redirect_to admin_faq_path(@faq)
    else
      flash[:error] = 'FAQ not updated'
      render :edit
    end
  end

  # DELETE /admin/faqs/:id/destroy
  def destroy
    if @faq.destroy
      flash[:success] = 'FAQ destroyed'
    else
      flash[:error] = 'FAQ not destroyed'
    end

    redirect_to admin_faqs_path
  end

  private

  def fetch_faq
    @faq = Faq.find(params[:id])
  end

  def fetch_params
    params.require(:faq).permit(:title, :body, :priority)
  end
end
