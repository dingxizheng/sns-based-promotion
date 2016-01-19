json.array!(promotions) do |promotion|
  # json.partial! :partial => 'promotions/promotion', :locals => { :promotion => promotion }
  render_partial json, 'promotions/promotion', { :promotion => promotion }
end
