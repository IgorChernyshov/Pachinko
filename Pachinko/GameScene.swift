//
//  GameScene.swift
//  Pachinko
//
//  Created by Igor Chernyshov on 07.07.2021.
//

import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

	// MARK: - Labels
	private var ballsLabel: SKLabelNode!
	private var editLabel: SKLabelNode!

	// MARK: - Properties
	private static let ballColors = ["Blue", "Cyan", "Green", "Grey", "Purple", "Red", "Yellow"]

	private var ballsCount = 5 {
		didSet {
			ballsLabel.text = "Score: \(ballsCount)"
		}
	}

	private var editingMode: Bool = false {
		didSet {
			if editingMode {
				editLabel.text = "Done"
			} else {
				editLabel.text = "Edit"
			}
		}
	}

	// MARK: - Lifecycle
	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background.jpg")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)

		physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
		physicsWorld.contactDelegate = self

		makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
		makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
		makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
		makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

		makeBouncer(at: CGPoint(x: 0, y: 0))
		makeBouncer(at: CGPoint(x: 256, y: 0))
		makeBouncer(at: CGPoint(x: 512, y: 0))
		makeBouncer(at: CGPoint(x: 768, y: 0))
		makeBouncer(at: CGPoint(x: 1024, y: 0))

		ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
		ballsLabel.text = "Balls: \(ballsCount)"
		ballsLabel.horizontalAlignmentMode = .right
		ballsLabel.position = CGPoint(x: 980, y: 700)
		addChild(ballsLabel)

		editLabel = SKLabelNode(fontNamed: "Chalkduster")
		editLabel.text = "Edit"
		editLabel.position = CGPoint(x: 80, y: 700)
		addChild(editLabel)
	}

	// MARK: - Game Logic
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let location = touch.location(in: self)

			let objects = nodes(at: location)

			if objects.contains(editLabel) {
				editingMode.toggle()
			} else {
				if editingMode {
					makeBox(at: location)
				} else {
					makeBall(at: location)
				}
			}
		}
	}

	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }

		if nodeA.name == "ball" {
			collisionBetween(ball: nodeA, object: nodeB)
		} else if nodeB.name == "ball" {
			collisionBetween(ball: nodeB, object: nodeA)
		}
	}

	func collisionBetween(ball: SKNode, object: SKNode) {
		if object.name == "good" {
			destroy(object: ball)
			ballsCount += 1
		} else if object.name == "bad" {
			destroy(object: ball)
		} else if object.name == "box" {
			destroy(object: object)
		}
	}

	private func destroy(object: SKNode) {
		if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
			fireParticles.position = object.position
			addChild(fireParticles)
		}
		object.removeFromParent()
	}

	// MARK: - Objects Production
	private func makeBouncer(at position: CGPoint) {
		let bouncer = SKSpriteNode(imageNamed: "bouncer")
		bouncer.position = position
		bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width * 0.5)
		bouncer.physicsBody?.isDynamic = false
		addChild(bouncer)
	}

	private func makeSlot(at position: CGPoint, isGood: Bool) {
		var slotBase: SKSpriteNode
		if isGood {
			slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
			slotBase.name = "good"
		} else {
			slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
			slotBase.name = "bad"
		}
		slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
		slotBase.physicsBody?.isDynamic = false
		slotBase.position = position
		addChild(slotBase)

		let slotGlow = isGood ? SKSpriteNode(imageNamed: "slotGlowGood") : SKSpriteNode(imageNamed: "slotGlowBad")
		slotGlow.position = position
		addChild(slotGlow)

		let spin = SKAction.rotate(byAngle: .pi, duration: 10)
		let spinForever = SKAction.repeatForever(spin)
		slotGlow.run(spinForever)
	}

	private func makeBall(at position: CGPoint) {
		if ballsCount <= 0 { return makePuff(at: position) }
		if position.y < 600 { return blinkBorder() }
		let ballName = "ball\(GameScene.ballColors.randomElement() ?? "Red")"
		let ball = SKSpriteNode(imageNamed: ballName)
		ball.name = "ball"
		ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width * 0.5)
		ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
		ball.physicsBody?.restitution = 0.4
		ball.position = position
		addChild(ball)
		ballsCount -= 1
	}

	private func makeBox(at position: CGPoint) {
		if position.y > 600 { return blinkBorder() }
		let size = CGSize(width: Int.random(in: 16...128), height: 16)
		let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
		box.name = "box"
		box.zRotation = CGFloat.random(in: 0...3)
		box.position = position

		box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
		box.physicsBody?.isDynamic = false

		addChild(box)
	}

	private func blinkBorder() {
		let border = SKSpriteNode(color: .red, size: CGSize(width: UIScreen.main.bounds.maxX, height: 4))
		border.position = CGPoint(x: UIScreen.main.bounds.midX, y: 600)
		addChild(border)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			border.removeFromParent()
		}
	}

	private func makePuff(at position: CGPoint) {
		guard let puff = SKEmitterNode(fileNamed: "PuffParticles") else { return }
		puff.position = position
		addChild(puff)
	}
}
