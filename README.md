# F1-Vision | Boilermake XII Hackathon

## Video Demo

You can watch the demo of F1-Vision in action below:

[![F1-Vision Demo](https://img.youtube.com/vi/LIaMqRZfTxU/0.jpg)](https://www.youtube.com/watch?v=LIaMqRZfTxU)

## Inspiration

As sporting events like Formula 1 become more expensive and exclusive to the physical experience, many fans are unable to immerse themselves in their favorite sports. Watching F1 on TV every weekend can become boring and repetitive. People often feel like they're missing out on the real excitement and thrill of the sport.

What's more, F1 is not just about cars racing around a track, it's about strategy, quick decisions, and minute technical details that make all the difference. At the same time, there is a growing shift in the sports world towards data analytics and immersive technologies. As more teams, analysts, and fans alike rely on detailed statistics to understand games, the demand for a more engaging and analytical experience has grown.

The best way to change that is to make it more interactive. Make the game feel around you, immerse you in those moments. That is why we created **F1-Vision**, the best way to experience F1, not just watch it.

## What it does

With **F1-Vision**, we bridge the gap between live races and data, putting personalized control at the fingertips of the viewer. 

### Features:
- **Interactive Maps & Dashboards**: Watch live, location-based races with personalized data visualizations such as tire wear, sector times, and radio messages, live from the race.
- **Exciting Commentary**: Enjoy insightful commentary and in-app race alerts so you don't miss a thing.
- **Real-Time Updates**: Access live race data, including tire wear and sector times, and track the race with continuous updates.

## How we built it

We used Python to scrape various types of F1 data, which we then parsed and enhanced with additional features such as relative time (time that starts when the race starts). The data was stored in JSON format for easy access.

The development took place on **VisionOS** for the **Apple Vision Pro**, utilizing **XCode** and **Swift**. Some of the key components include:
- **Data Scraping & Parsing**: Using Python to fetch and format the F1 data, storing it in JSON files.
- **VisionOS Development**: Developed a rich UI experience with Swift, integrating dynamic dashboards, notifications, and video commentary.
- **AI-Driven Commentary**: Integrated a two-model pipeline to generate commentary using Llama and **Whisper-Speech** for voice replication, bringing a realistic, high-quality commentary experience.
- **3D Simulation**: Created a 3D model of the Bahrain F1 track using **Blender** and **Reality Kit SDK** to bring the experience to life. The race simulation tracks data points in 3D space and renders them with realistic lighting and animations.

## Challenges we ran into

- **Data Scraping & Relative Time**: Scraping various data types with different timestamps and relative times presented a complex challenge.
- **Graphics & 3D Models**: Implementing interactive 3D models and managing high-quality graphics within VisionOS required acquiring new skills, due to limited documentation and support for VisionOS.
- **Data Flow Integration**: Integrating high-speed data flow into Swift proved challenging, but we solved it by creating a custom running loop that acted as an internal system clock, ensuring smooth data updates.

## Accomplishments that we're proud of

- **VisionOS Implementation**: Successfully learned and implemented VisionOS, working with cutting-edge technology that was previously unexplored.
- **VR/AR Technologies**: Smooth implementation of immersive VR/AR experiences, including realistic 3D models, animations, and interactive elements.
- **High-Quality UI**: Developed a high-quality user interface with animations and real-time updates.
- **High-Speed Data Management**: Efficiently managed and displayed live race data in real-time.

## What we learned

- **VisionOS Development**: Gained a deep understanding of VisionOS, Swift, and Reality Kit SDK, as well as how to structure and manage JSON data.
- **Speech Replication**: Explored how text-to-speech models like **Whisper-Speech** work, allowing us to replicate famous commentators' voices.
- **3D Modeling & Simulation**: Learned about 3D model design and simulation techniques, especially for VR/AR use cases.

## What's next for F1-Vision

With **F1-Vision**, we're changing the way people experience F1. Our plans for the future include:
- **Enhanced Features**: Adding more maps, replays, camera angles, and better views.
- **Improved Scoring System**: Improving the scoring system and race predictions using machine learning models.
- **Community Integration**: Exploring ways to integrate community-based systems to interact with fans and allow for greater engagement.

## Built With

- **groq-cloud**
- **Python**
- **Reality Kit**
- **Swift** and **SwiftUI**
- **Sync.so**
- **VisionOS**
- **Whisper-Speech** 
