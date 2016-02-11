json.array!(subscribables) do |sub|
  # json.partial! :partial => 'promotions/promotion', :locals => { :promotion => promotion }
  render_partial json, 'subscribables/subscribable', { :subscribable => sub }
end
