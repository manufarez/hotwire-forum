module Discussions
  class PostsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_discussion
    before_action :set_post, only: [:show, :edit, :update, :destroy]

    def create
      @post = @discussion.posts.new(post_params)

      respond_to do |format|
        if @post.save
          #If the post 'redirect' parameter is present, redirect to the last page (html response)
          if params.dig('post', 'redirect').present?
            @pagy, @posts = pagy(@discussion.posts.order(created_at: :desc), items: 5)
            format.html { redirect_to discussion_path(@discussion, page: @pagy.last), notice: "Post submitted"}
          else
            @post = @discussion.posts.new
            format.turbo_stream
          end
        else
          format.turbo_stream
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def show
      sleep 2
    end

    def edit
    end

    def update
      respond_to do |format|
        if @post.update(post_params)
          format.html { redirect_to @post.discussion, notice: "Post updated"}
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @post.destroy

      respond_to do |format|
        format.turbo_stream { } #empty response - do nothing here
        format.html { redirect_to @post.discussion, notice: "Post deleted"}
      end
    end

    private
    def set_discussion
      @discussion = Discussion.find(params[:discussion_id])
    end

    def set_post
      @post = @discussion.posts.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:body)
    end
  end
end
