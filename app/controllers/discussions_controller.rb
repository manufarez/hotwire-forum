class DiscussionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discussion, only: [:edit, :update, :destroy, :show]

  def index
    @discussions = Discussion.all.order(updated_at: :desc)
  end

  def new
    @discussion = Discussion.new
    @discussion.posts.new
  end

  def show
    @new_post = @discussion.posts.new
    @posts = @discussion.posts.all.order(created_at: :asc)
  end

  def create
    @discussion = Discussion.new(discussion_params)

    respond_to do |format|
      if @discussion.save
        format.html { redirect_to @discussion, notice: 'Discussion created' }
      else
        format.html { render :new, status: :unprocessable_entity}
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @discussion.update(discussion_params)
        @discussion.broadcast_replace(partial: "discussions/header", locals: {discussion: @discussion})
        format.html { redirect_to @discussion, notice: 'Discussion updated' }
      else
        format.html { render :edit, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @discussion.destroy!
    redirect_to discussions_path, notice: 'Discussion removed'
  end

  private

  def set_discussion
    @discussion = Discussion.find(params[:id])
  end

  def discussion_params
    params.require(:discussion).permit(:name, :pinned, :closed, :category_id, posts_attributes: :body)
  end
end
