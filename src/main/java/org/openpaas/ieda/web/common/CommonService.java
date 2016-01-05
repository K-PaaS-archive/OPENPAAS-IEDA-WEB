package org.openpaas.ieda.web.common;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.swing.filechooser.FileNameExtensionFilter;

import org.apache.commons.io.IOUtils;
import org.openpaas.ieda.common.LocalDirectoryConfiguration;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class CommonService {

	
	public void uploadKeyFile(MultipartHttpServletRequest request) {
		Iterator<String> itr =  request.getFileNames();
		File keyPathFile = new File(LocalDirectoryConfiguration.getSshDir());
		if (!keyPathFile.isDirectory()){
			keyPathFile.mkdir();
		}
			
        if(itr.hasNext()) {
            MultipartFile mpf = request.getFile(itr.next());
            try {
            	String keyFilePath = LocalDirectoryConfiguration.getSshDir() + System.getProperty("file.separator") + mpf.getOriginalFilename();
                byte[] bytes = mpf.getBytes();
                BufferedOutputStream stream =
                        new BufferedOutputStream(new FileOutputStream(new File(keyFilePath)));
                stream.write(bytes);
                stream.close();
            } catch (IOException e) {
                log.info(e.getMessage());
                e.printStackTrace();
            }
        } 
	}

	public List<String> getKeyFileList() {

		FileNameExtensionFilter filter = new FileNameExtensionFilter("KeyFile only","pem");
		
		File keyPathFile = new File(LocalDirectoryConfiguration.getSshDir());
		if ( !keyPathFile.isDirectory() ) return null;
		
		List<String> localFiles = null;
		
		File[] listFiles = keyPathFile.listFiles();
		for (File file : listFiles) {
			
			if(!file.getName().endsWith(".pem") && !file.getName().endsWith(".PEM"))
				continue;
			
			if ( localFiles == null )
				localFiles = new ArrayList<String>();

			localFiles.add(file.getName());
		}
		
		return localFiles;
	}

	public String getDeploymentInfo(String deploymentFile) {
		String contents = "";
		File settingFile = null;
		try {
			settingFile = new File(LocalDirectoryConfiguration.getDeploymentDir() + System.getProperty("file.separator") + deploymentFile);
			contents = IOUtils.toString(new FileInputStream(settingFile), "UTF-8");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return contents;
	}
}
