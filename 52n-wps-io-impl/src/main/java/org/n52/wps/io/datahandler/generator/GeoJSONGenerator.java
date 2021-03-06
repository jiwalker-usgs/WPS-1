/**
 * Copyright (C) 2013
 * by 52 North Initiative for Geospatial Open Source Software GmbH
 * 
 * Contact: Andreas Wytzisk
 * 52 North Initiative for Geospatial Open Source Software GmbH
 * Martin-Luther-King-Weg 24
 * 48155 Muenster, Germany
 * info@52north.org
 * 
 * This program is free software; you can redistribute and/or modify it under 
 * the terms of the GNU General Public License version 2 as published by the 
 * Free Software Foundation.
 * 
 * This program is distributed WITHOUT ANY WARRANTY; even without the implied
 * WARRANTY OF MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * this program (see gnu-gpl v2.txt). If not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA or
 * visit the Free Software Foundation web page, http://www.fsf.org.
 * 
 */
package org.n52.wps.io.datahandler.generator;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.geojson.feature.FeatureJSON;
import org.geotools.geojson.geom.GeometryJSON;
import org.n52.wps.io.data.IData;
import org.n52.wps.io.data.binding.complex.GTVectorDataBinding;
import org.n52.wps.io.data.binding.complex.JTSGeometryBinding;

import com.vividsolutions.jts.geom.Geometry;

/**
 * This class generates a GeoJSON String representation out of a JTS Geometry.
 * @author BenjaminPross(bpross-52n)
 *
 */
public class GeoJSONGenerator extends AbstractGenerator {

	public GeoJSONGenerator(){
		super();
		supportedIDataTypes.add(JTSGeometryBinding.class);
		supportedIDataTypes.add(GTVectorDataBinding.class);
	}
	
	@Override
	public InputStream generateStream(IData data, String mimeType, String schema)
			throws IOException {
		
		if(data instanceof JTSGeometryBinding){
			Geometry g = ((JTSGeometryBinding)data).getPayload();
			
			File tempFile = File.createTempFile("wps", "json");
			finalizeFiles.add(tempFile); // mark for final delete
			
			 new GeometryJSON().write(g, tempFile);
					
			InputStream is = new FileInputStream(tempFile);
			
			return is;
		}else if(data instanceof GTVectorDataBinding){
			
			SimpleFeatureCollection f = (SimpleFeatureCollection)data.getPayload();
			
			File tempFile = File.createTempFile("wps", "json");
			finalizeFiles.add(tempFile); // mark for final delete
			
			 new FeatureJSON().writeFeatureCollection(f, tempFile);
					
			InputStream is = new FileInputStream(tempFile);
			
			return is;
		}
		
		return null;
	}

}
