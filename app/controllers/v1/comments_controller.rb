class V1::CommentsController < ApplicationController

  include VoteableActions
  voteable :comment

  before_action :restrict_access, only: [:update, :destory, :create, :vote_up, :vote_down]
  before_action :set_comment, except: [:index, :create]
  before_action :set_commentee, except: []

  # models that could be commented on
  COMMENTABLES = [User, Promotion]

  # GET /comments
  def index
    @comments = CommentPolicy::Scope.new(current_user, @commentee.comments)
                  .resolve
                  .query_by_params(query_params)
                  .query_by_text(search)
                  .sortby(sortBy)
                  .paginate(page, per_page)
    render_json 'comments/comments', :locals => { :comments => @comments }
  end

  # GET /comments/1
  def show
    render_json 'comments/comment', :locals => { :comment => @comment }
  end

  # POST /comments
  def create
    @comment = @commentee.comments.build(comment_params.merge!(commenteer_id: current_user.get_id))
    raise UnprocessableEntityError.new(@comment.errors) unless @comment.save
    moderatorize current_user, @comment
    render_json 'comments/comment', :locals => { :comment => @comment }, status: :created
  end

  # PATCH/PUT /comments/1
  def update
    authorize @comment
    raise UnprocessableEntityError.new(@comment.errors) unless @comment.update(comment_params)     
    render_json 'comments/comment', :locals => { :comment => @comment }
  end

  # DELETE /comments/1
  def destroy
    authorize @comment
    @comment.destroy
    head :no_content
  end

  private
    def set_commentee
      @commentee = nil
      COMMENTABLES.reverse.each do |model|
        id_name = "#{model.name.downcase}_id".to_sym
        @commentee = model.find(params[id_name] || "")
        break unless @commentee.nil?
      end
      raise BadRequestError.new(I18n.t('errors.requests.no_commentee')) if @commentee.nil?
    end

    def set_comment
      @comment = Comment.find(params[:id] || params[:comment_id])
      raise NotfoundError.new(I18n.t('errors.requests.default_not_found') % request.path) if @comment.nil?
    end

    def comment_params  
      params.permit(:body, :parent_id)
    end

end