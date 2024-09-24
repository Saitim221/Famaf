package feed;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class FeedParser {

    public static List<Article> parseXML(String xmlData) {
        List<Article> articles = new ArrayList<>();

        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(new ByteArrayInputStream(xmlData.getBytes()));

            Element root = document.getDocumentElement();
            NodeList itemNodes = root.getElementsByTagName("item");

            for (int i = 0; i < itemNodes.getLength(); i++) {
                Element itemElement = (Element) itemNodes.item(i);
                NodeList titleList = itemElement.getElementsByTagName("title");
                String title = titleList.getLength() > 0 ? titleList.item(0).getTextContent() : "";

                NodeList linkList = itemElement.getElementsByTagName("link");
                String link = linkList.getLength() > 0 ? linkList.item(0).getTextContent() : "";

                NodeList descriptionList = itemElement.getElementsByTagName("description");
                String description = descriptionList.getLength() > 0 ? descriptionList.item(0).getTextContent() : "";

                NodeList pubDateList = itemElement.getElementsByTagName("pubDate");
                String pubDate = pubDateList.getLength() > 0 ? pubDateList.item(0).getTextContent() : "";

                Article article = new Article(title, description, link, pubDate);
                articles.add(article);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return articles;
    }

    public static String fetchFeed(String feedURL) throws MalformedURLException, IOException, Exception {

        URL url = new URL(feedURL);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();

        connection.setRequestMethod("GET");
        connection.setRequestProperty("Content-Type", "application/json");

        // TODO: Cambiar el user-agent al nombre de su grupo. 
        // Si todos los grupos usan el mismo user-agent, el servidor puede bloquear las solicitudes.
        connection.setRequestProperty("User-agent", "lab_paradigmas");
        connection.setConnectTimeout(5000);
        connection.setReadTimeout(5000);

        int status = connection.getResponseCode();
        if (status != 200) {
            throw new Exception("HTTP error code: " + status);
        } else {
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String inputLine;
            StringBuffer content = new StringBuffer();
            while ((inputLine = in.readLine()) != null) {
                content.append(inputLine);
            }
            in.close();
            connection.disconnect();
            return content.toString();
        }
    }
}
