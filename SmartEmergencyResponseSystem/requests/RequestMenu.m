classdef RequestMenu
    %REQUESTMENU 
    
    methods (Static)
        function open(request)
            prompts = {'Requested Item:';
                       'Emergency Responder Name:';
                       'Requested Service Type (D: Delivery, P: Pick Up):';
                       'Quantity';
                       'Priority of Request (1: High - 10: Low):';
                       'Latitude:';
                       'Longitude:'};

            defaults = {request.item.name;
                        request.sender;
                        '';
                        num2str(request.quantity);
                        num2str(request.priority);
                        sprintf('%12f7',request.location(1));
                        sprintf('%12f7',request.location(2))};
            if request.isPickup
                defaults{3} = 'P';
            elseif request.isDelivery
                defaults{3} = 'D';
            end
            
            while true                
                newRequestData = inputdlg(prompts,...
                                          'Enter request information',...
                                          1,...
                                          defaults);
                if isempty(newRequestData)
                    return;
                end
                
                if RequestMenu.validateItem(newRequestData{1}) && ...
                   RequestMenu.validateServiceType(newRequestData{3}) && ...
                   RequestMenu.validateQuantity(newRequestData{4}) && ...
                   RequestMenu.validatePriority(newRequestData{5}) && ...
                   RequestMenu.validateLatitude(newRequestData{6}) && ...
                   RequestMenu.validateLongitude(newRequestData{7})
                    break;   % Everything validated, so move on
                end
            end
            
            request.item = ItemFactory.makeItem(newRequestData{1});
            request.sender = newRequestData{2};
            request.isPickup = strcmp('P',newRequestData{3});
            request.isDelivery = strcmp('D',newRequestData{3});
            request.quantity = str2double(newRequestData{4});
            request.priority = str2double(newRequestData{5});
            request.location = [str2double(newRequestData{6}),...
                                str2double(newRequestData{7})];
        end
        
        function retval = validateItem(item)
            retval = any(strcmp(ItemFactory.getCatalog,item));
            if ~retval
                uiwait(errordlg('Invalid item name',...
                                'Invalid input',...
                                'modal'));
            end
        end
        
        function retval = validateServiceType(serviceType)
            if ~any(strcmp({'D','P'},serviceType))
                uiwait(errordlg('Requested Service Type must be either D or P',...
                                'Invalid input',...
                                'modal'));
                retval = false;
            else
                retval = true;
            end
        end
        
        function retval = validateQuantity(quantity)
            try
                quantity = str2double(quantity);
                if quantity <=0
                    error('');
                end
                retval = true;
            catch
                uiwait(errordlg('Requested quantity must be positive',...
                                'Invalid input',...
                                'modal'));
                retval = false;
            end
        end
        
        function retval = validatePriority(priority)
            try
                priority = str2double(priority);
                if ~(priority <= 10 && priority >=1)
                    error('');
                end
                retval = true;
            catch
                uiwait(errordlg('Priority must be between 1 and 10',...
                                'Invalid input',...
                                'modal'));
                retval = false;
            end
        end
        
        function retval = validateLatitude(latitude)
            try
                latitude = str2double(latitude);
                if ~(latitude <= 90 && latitude >= -90)
                    error('');
                end
                retval = true;
            catch
                uiwait(errordlg('Latitude must be between -90 and 90',...
                                'Invalid input',...
                                'modal'));
                retval = false;
            end
        end
        
        function retval = validateLongitude(longitude)
            try
                longitude = str2double(longitude);
                if ~(longitude <= 180 && longitude >= -180)
                    error('');
                end
                retval = true;
            catch
                uiwait(errordlg('Longitude must be between -90 and 90',...
                                'Invalid input',...
                                'modal'));
                retval = false;
            end            
        end
    end
    
end

