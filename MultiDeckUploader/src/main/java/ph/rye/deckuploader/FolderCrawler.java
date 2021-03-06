/**
 *   Copyright 2016 Royce Remulla
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package ph.rye.deckuploader;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.List;

/**
 * @author royce
 *
 */
public class FolderCrawler {


    public List<String> getFiles(final String path,
                                 final String fileExtension) {
        final List<String> retval = new ArrayList<>();

        final File folder = new File(path);
        final File[] listOfFiles = folder.listFiles(
            (FilenameFilter) (dir, name) -> name.endsWith(fileExtension));

        for (int i = 0; i < listOfFiles.length; i++) {
            if (listOfFiles[i].isFile()) {
                retval.add(listOfFiles[i].getName());
            }
        }
        return retval;
    }


    /**
     * @param args
     */
    public static void main(final String[] args) {
        new FolderCrawler().getFiles(
            "/Users/royce/Dropbox/Documents/Reviewer/javascript/",
            ".txt");

    }

}
