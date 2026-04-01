Title: Easing and duration – Material Design 3

URL Source: http://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

link

Copy link Link copied

Suggested easing and duration pairs
-----------------------------------

link

Copy link Link copied

Choosing the right combination of easing and duration can be complicated. As a simple starting point, these are sensible defaults that will work for most transitions.

| **Easing** | **Duration** | **Transition type** |
| --- |
| Emphasized | 500ms | Begin and end on screen |
| Emphasized decelerate | 400ms | Enter the screen |
| Emphasized accelerate | 200ms | Exit the screen |
| Standard | 300ms | Begin and end on screen |
| Standard decelerate | 250ms | Enter the screen |
| Standard accelerate | 200ms | Exit the screen |

link

Copy link Link copied

Easing
------

link

Copy link Link copied

In the physical world, objects don’t start or stop instantaneously. Instead, they take time to speed up and slow down. Transitions without easing look stiff and mechanical, while a transition with easing appears more natural.

1.   A transition with easing
2.   A transition without easing

link

Copy link Link copied

Compared to the utilitarian style of M2, M3 easing is more expressive. Transitions have snappy take offs and very soft landings.

Durations are slightly longer compared to M2. This gives transitions time to come to a gentle rest without feeling abrupt.

1.   M2 easing and duration
2.   M3 easing and duration

link

Copy link Link copied

### Choosing an easing set

link

Copy link Link copied

The [**Emphasized easing set**](https://m3.material.io/m3/pages/motion-easing-and-duration/tokens-specs#cbea5c6e-7b0d-47a0-98c3-767080a38d95) is recommended for most transitions to capture the style of M3.

The [**Standard easing set**](https://m3.material.io/m3/pages/motion-easing-and-duration/tokens-specs#601d5552-a6e6-4d74-9886-ff8f24b9ec35) can be used for small utility focused transitions that need to be quick. The Standard set is also a fallback for platforms that don't support Emphasized easing, like iOS and Web.

Emphasized easing is used for this full screen transition

Standard easing is used for this Text field transition on Web. The simple style fits the utility of this component.

link

Copy link Link copied

### Choosing an easing type

Easing types are chosen based on how a transition moves in relation to the screen.

link

Copy link Link copied

#### Begin and end on screen

These transitions use **Emphasized** easing. It speeds up quickly and then comes to a gentle rest in order to emphasize the end of the transition.

This transition begins and ends on screen so it uses Emphasized easing

link

Copy link Link copied

#### Enter the screen

These transitions use **Emphasized decelerate** easing. It begins at peak velocity then comes to a gentle rest.

#### Exit the screen permanently

These transitions use **Emphasized accelerate** easing. It begins at rest and ends at peak velocity. By ending at peak velocity, it gives the impression the exiting component cannot be retrieved.

This Bottom sheet enters with Emphasized decelerate and exits permanently with Emphasized accelerate

link

Copy link Link copied

#### Exit the screen temporarily

These transitions use **Emphasized** easing. By ending at rest just off screen, it gives the impression the exiting component can be retrieved.

This drawer enters and exits temporarily with Emphasized easing

link

Copy link Link copied

Duration
--------

link

Copy link Link copied

Transitions shouldn’t be jarringly fast or so slow that users feel as though they’re waiting. The right combination of duration and easing produces smooth and responsive transitions.

check Do 
A transition with a well tuned duration is quick and easy to follow

close Don’t 
Avoid transitions with such a short duration they become jarring

link

Copy link Link copied

### Choosing a duration

Durations are chosen based on these criteria:

link

Copy link Link copied

#### Transition size

Transitions that cover small areas of the screen have short durations. Those that traverse large areas have long durations. Scaling duration with the size of a transition area gives a consistent sense of speed.

This transition covers a small area with a short 200ms duration

This transition covers a large area with a long 500ms duration

link

Copy link Link copied

#### Enter vs. exit transitions

Transitions that exit, dismiss, or collapse an element use shorter durations. Exit transitions are faster because they require less attention than the user’s next task.

Transitions that enter or remain persistent on the screen use longer durations. This helps users focus attention on what's new on screen.

1.   An Enter transition has a long duration of 500ms
2.   An Exit transition has a short duration of 200ms

link

Copy link Link copied

1.   An Enter transition has a long duration of 500ms
2.   An Exit transition has a short duration of 200ms
