classdef site_T_SWC_flux_data
properties
    sitecode;
    surfaces;
    clim_spaces;
    note;
end

methods

%--------------------------------------------------
    function obj = site_T_SWC_flux_data( sitecode, ...
                                         sfc_shallow, ...
                                         sfc_mid, ...
                                         sfc_deep, ...
                                         clim_shallow, ...
                                         clim_mid, ...
                                         clim_deep, ...
                                         note )
    
    obj.sitecode = sitecode;
    obj.surfaces = struct( 'shallow', sfc_shallow, ...
                           'mid', sfc_mid, ...
                           'deep', sfc_deep);
    obj.clim_spaces = struct( 'shallow_day', clim_shallow, ...
                              'mid', clim_mid, ...
                              'deep', clim_deep);
    obj.note = note;
    end  % constructor

%--------------------------------------------------
    function h_fig =  plot( obj, varargin )

    h_fig = figure( 'Units', 'Inches', ...
                    'Position', [ 0, 0, 24, 13 ], ...
                    'Visible', 'on' );

    % one panel for the flux kernel regression, one for each climate space year,
    % and one for the all-time climate space
    n_panels_h = numel( obj.clim_spaces.deep1.year_idx ) + 2;
    n_panels_v = 4; % four SWC depth panels vertically

    % plot the NEE--T--SWC surfaces
    % loop iterators: fi - "field iterator"
    sfc_flds = fieldnames( obj.surfaces );
    for fi = 2:numel( sfc_flds )   % do not plot shallow/night surface
        this_ax = subplotrc( n_panels_v, n_panels_h, fi - 1, 1 );
        plot( obj.surfaces.( sfc_flds{ fi } ), ...
              'ax', this_ax, ...
              'main_title', '', ...
              'cbar_lab', 'NEE' );
    end

    % determine the largest fraction in the climate spaces so that all annual
    % climate space plots can have the same color scale
    all_annual_cs = [ obj.clim_spaces.shallow_day.year_clim_space, ...
                      obj.clim_spaces.deep1.year_clim_space, ...
                      obj.clim_spaces.deep2.year_clim_space, ...
                      obj.clim_spaces.deep3.year_clim_space ];
    max_frac = max( reshape( all_annual_cs, [], 1 ) );
    
    % plot the annual climate spaces
    % loop iterators: fi - "field iterator", yi - "year iterator"
    clim_flds = fieldnames( obj.clim_spaces );
    for fi = 1:numel( clim_flds )
        this_cs = obj.clim_spaces.( clim_flds{ fi } );
        for yi = 1:numel( this_cs.year_idx )
            this_ax = subplotrc( n_panels_v, n_panels_h, fi, 1 + yi );
            [ T_grid, swc_grid ] = meshgrid( this_cs.T_val, ...
                                             this_cs.swc_val ); 
            contourf( this_ax, ...
                      T_grid, ...
                      swc_grid, ...
                      this_cs.year_clim_space( :, :, yi ) * 100.0 );
            h_cbar = colorbar();
            set( get( h_cbar, 'Title' ), ...
                 'String', '% days' );
            set( this_ax, 'clim', [ 0, max_frac * 100.0 ] );
            title( this_cs.year_idx( yi ) );
            
            % draw gridlines at the SWC edges -- their spacing is contstant
            % in log space so is perhaps counterintuitive when plotted in
            % decimal space
            for i = 1:numel( this_cs.swc_val )
                h_line = refline( 0, this_cs.swc_val( i ) );
                set( h_line, 'Color', 'black', 'LineStyle', ':' );
            end
        end
        fi = fi + 1;
    end
    
    % plot the all-time climate spaces
    
    all_alltime = [ obj.clim_spaces.shallow_day.alltime_clim_space, ...
                    obj.clim_spaces.deep1.alltime_clim_space, ...
                    obj.clim_spaces.deep2.alltime_clim_space, ...
                    obj.clim_spaces.deep3.alltime_clim_space ];
    alltime_max_frac = max( reshape( all_alltime, [], 1 ) );
    
    % loop iterators: fi - "field iterator"
    clim_flds = fieldnames( obj.clim_spaces );
    for fi = 1:numel( clim_flds )
        this_cs = obj.clim_spaces.( clim_flds{ fi } );
        this_ax = subplotrc( n_panels_v, n_panels_h, fi, n_panels_h );
        [ T_grid, swc_grid ] = meshgrid( this_cs.T_val, ...
                                         this_cs.swc_val ); 
        contourf( this_ax, ...
                  T_grid, ...
                  swc_grid, ...
                  this_cs.alltime_clim_space * 100.0 );
        h_cbar = colorbar();
        set( this_ax, 'clim', [ 0, alltime_max_frac * 100.0 ] );
        set( get( h_cbar, 'Title' ), ...
             'String', '% days' );
        title( 'all-time' );
        
        % draw gridlines at the SWC edges -- their spacing is contstant
        % in log space so is perhaps counterintuitive when plotted in
        % decimal space
        for i = 1:numel( this_cs.swc_val )
            h_line = refline( 0, this_cs.swc_val( i ) );
            set( h_line, 'Color', 'black', 'LineStyle', ':' );
        end
        
        fi = fi + 1;
    end

    suptitle( char( UNM_sites( obj.sitecode ) ) );
    
    end  % plot method
%--------------------------------------------------

end  % methods
end  % classdef


