from rest_framework.renderers import JSONRenderer

class CustomJSONRenderer(JSONRenderer):
    def render(self, data, accepted_media_type=None, renderer_context=None):
        response = renderer_context.get('response') if renderer_context else None
        
        # Check if we are rendering a Swagger/OpenAPI schema
        # Typically schemas contain 'openapi', 'swagger', or 'info' keys at the root
        if isinstance(data, dict) and any(key in data for key in ['openapi', 'swagger', 'info']):
            return super().render(data, accepted_media_type, renderer_context)

        status_code = response.status_code if response else 200
        
        if status_code >= 400:
            success = False
            message = 'Error occurred'
            # Check if there is a specific detail message
            if isinstance(data, dict):
                if 'detail' in data:
                    message = data.pop('detail')
                elif 'non_field_errors' in data:
                    message = data.pop('non_field_errors')[0]
                else:
                    # Generic error dictionary
                    message = str(data)
        else:
            success = True
            message = 'ok'
            
        # Avoid double-wrapping if data is already in expected format
        if isinstance(data, dict) and 'success' in data and 'data' in data:
            return super().render(data, accepted_media_type, renderer_context)

        custom_data = {
            'success': success,
            'message': message,
            'data': data
        }
        return super().render(custom_data, accepted_media_type, renderer_context)
