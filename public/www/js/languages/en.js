angular.module('starter.language', [])

.constant('englishLang', {

    menu: {
        back_btn_name: 'Back',
        title: 'Vicinity Deals',
        search_btn_name: 'Search',
        profile_btn_name: 'Profile',
        store_btn_name: 'Store',
        signin_btn_name: 'Sign In',
        signout_btn_name: 'Sign Out'
    },

    search: {
        search_btn_name: 'Search',
        suggested_dealers: 'Suggested Results',
        suggested_deals: 'Suggested Results',
        no_result_text_dealers: 'no result',
        no_result_text_deals: 'no result',
        no_result_text_all: 'no result',
        options_location: 'Location',
        options_location_toggle_name: 'Search By Distance',
        tab_title_business: 'Business',
        tab_title_deals: 'Deals',
        tab_title_all: 'All',
        tab_title_options: 'Options'

    },

    login: {
        title: 'Signin',
        cancel_btn_name: 'Cancel',
        register_btn_name: 'Register',
        form_label_email: 'Email',
        form_label_pass: 'Password',
        form_error_email_empty: 'Email cannot be blank',
        form_error_email_wrong_format: 'Invalid email address',
        form_error_pass_empty: 'Password cannot be blank',
        form_error_pass_too_short: 'Password is too short',
        signin_btn_name: 'Sign in',
        forgot_password: 'forgot the password?'
    },

    signup: {
        title: 'Register',
        form_placeholder_name: 'Alex (for example)',
        form_label_name: 'Name',
        form_error_name_empty: 'Name cannot be blank',
        form_error_name_too_short: 'Name is too short',
        form_placeholder_email: 'alex@hotmail.com',
        form_label_email: 'Email',
        form_error_email_empty: 'Email cannot be blank',
        form_error_email_wrong_format: 'Invalid email address',
        form_placeholder_pass: 'Password',
        form_label_pass: 'Password',
        form_error_pass_empty: 'Password cannot be blank',
        form_error_pass_too_short: 'Password must be longer than 4',
        form_error_pass_wrong_format: 'Password contains invalid characters',
        form_placeholder_pass_confirm: 'Password confirmation',
        form_label_pass_confirm: 'Confirm',
        form_error_pass_confirm_not_match: 'Does not match',
        sign_up_btn_name: 'Register'

    },

    promotions: {
        title: 'Promotions',
        customer_distance_formatter: function(distance) {
            return distance.toFixed(1) + ' kms away';
        },
    },

    editprofile: {
        title: 'Edit Profile',
        save_btn_name: 'Save',
        turn_on_business_toggle_name: 'Business User',
        
    }

});
