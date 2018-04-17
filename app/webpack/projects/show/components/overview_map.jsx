import _ from "lodash";
import React, { PropTypes } from "react";
import { Grid, Row, Col } from "react-bootstrap";
import TaxonMap from "../../../observations/identify/components/taxon_map";

const OverviewMap = ( { project } ) => {
  let title = I18n.t( "map_of_observations" );
  let totalBounds = project.recent_observations && project.recent_observations.total_bounds;
  if ( _.isEmpty( totalBounds ) && !_.isEmpty( project.placeRules ) ) {
    title = I18n.t( "map" );
    totalBounds = { swlat: null, swlng: null, nelat: null, nelng: null };
    _.each( project.placeRules, r => {
      if ( r.place && r.place.bounding_box_geojson ) {
        const coords = r.place.bounding_box_geojson.coordinates[0];
        totalBounds.swlat = ( totalBounds.swlat === null ?
          coords[0][1] : Math.min( totalBounds.swlat, coords[0][1] ) );
        totalBounds.swlng = ( totalBounds.swlng === null ?
          coords[0][0] : Math.min( totalBounds.swlng, coords[0][0] ) );
        totalBounds.nelat = ( totalBounds.nelat === null ?
          coords[1][1] : Math.max( totalBounds.nelat, coords[1][1] ) );
        totalBounds.nelng = ( totalBounds.nelng === null ?
          coords[2][0] : Math.max( totalBounds.nelng, coords[2][0] ) );
      }
    } );
  }
  return (
    <Grid>
      <Row>
        <Col xs={ 12 }>
          <h2>{ title }</h2>
          <TaxonMap
            observationLayers={ [project.search_params] }
            showAccuracy
            enableShowAllLayer={ false }
            clickable={ false }
            scrollwheel={ false }
            overlayMenu={ false }
            mapTypeControl
            mapTypeControlOptions={{
              style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
              position: google.maps.ControlPosition.TOP_LEFT
            }}
            zoomControlOptions={{ position: google.maps.ControlPosition.TOP_LEFT }}
            placeLayers={ _.isEmpty( project.placeRules ) ? null :
              [{ place: {
                id: _.map( project.placeRules, "operand_id" ).join( "," ),
                name: "Places"
              } }]
            }
            minZoom={ 2 }
            maxX={ totalBounds && totalBounds.nelng }
            maxY={ totalBounds && totalBounds.nelat }
            minX={ totalBounds && totalBounds.swlng }
            minY={ totalBounds && totalBounds.swlat }
          />
        </Col>
      </Row>
    </Grid>
  );
};

OverviewMap.propTypes = {
  project: PropTypes.object
};

export default OverviewMap;
