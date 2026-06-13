class TagsController < ApplicationController
  before_action :require_login
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  def index
    @tags = Tag.for_user(current_user)
  end

  def show
  end

  def new
    @tag = current_user.tags.build
  end

  def edit
    if @tag.required?
      redirect_to tags_path, alert: 'Cannot edit required tags.'
      return
    end
  end

  def create
    @tag = current_user.tags.build(tag_params)
    if @tag.save
      redirect_to @tag, notice: 'Тег успешно создан.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tag.required?
      redirect_to tags_path, alert: 'Нельзя редактировать обязательные теги.'
      return
    end
    if @tag.update(tag_params)
      redirect_to @tag, notice: 'Тег успешно обновлён.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @tag.required?
      redirect_to tags_path, alert: 'Нельзя удалять обязательные теги.'
      return
    end
    @tag.destroy
    redirect_to tags_url, notice: 'Тег успешно удалён.'
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end