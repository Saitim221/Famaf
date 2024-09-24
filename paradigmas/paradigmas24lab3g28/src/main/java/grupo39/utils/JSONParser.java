package grupo39.utils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

public class JSONParser {

    static public List<FeedsData> parseJsonFeedsData(String jsonFilePath) throws IOException {
        String jsonData = new String(Files.readAllBytes(Paths.get(jsonFilePath)));
        List<FeedsData> feedsList = new ArrayList<>();

        JSONArray jsonArray = new JSONArray(jsonData);
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.getJSONObject(i);
            String label = jsonObject.getString("label");
            String url = jsonObject.getString("url");
            String type = jsonObject.getString("type");
            feedsList.add(new FeedsData(label, url, type));
        }
        return feedsList;
    }

    public List<DictionaryData> parseJsonDictionaryData(String jsonFilePath) throws IOException {
        String jsonData = new String(Files.readAllBytes(Paths.get(jsonFilePath)));
        List<DictionaryData> dictionarylist = new ArrayList<>();

        JSONArray jsonArray = new JSONArray(jsonData);
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.getJSONObject(i);
            String label = jsonObject.getString("label");
            String category = jsonObject.getString("Category");
            //String topics = jsonObject.getString("Topics");
            List<String> topics = new ArrayList<>();
            for (int j = 0; j < jsonObject.getJSONArray("Topics").length(); j++) {
                topics.add((String) jsonObject.getJSONArray("Topics").get(j));
            }
            List<String> keywords = new ArrayList<>();
            for (int j = 0; j < jsonObject.getJSONArray("keywords").length(); j++) {
                keywords.add((String) jsonObject.getJSONArray("keywords").get(j));
            }
            dictionarylist.add(new DictionaryData(label, category, topics, keywords));

        }
        return dictionarylist;
    }
}
