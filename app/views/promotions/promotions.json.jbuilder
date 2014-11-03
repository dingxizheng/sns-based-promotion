json.array!(promotions) do |promotion|
  json.partial! :partial => 'promotions/promotion', :locals => { :promotion => promotion }
end
