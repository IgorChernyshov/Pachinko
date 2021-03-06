//
//  GameScene.swift
//  Pachinko
//
//  Created by Igor Chernyshov on 07.07.2021.
//

import SpriteKit

class GameScene: SKScene {

	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background.jpg")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)

		physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

		makeBouncer(at: CGPoint(x: 0, y: 0))
		makeBouncer(at: CGPoint(x: 256, y: 0))
		makeBouncer(at: CGPoint(x: 512, y: 0))
		makeBouncer(at: CGPoint(x: 768, y: 0))
		makeBouncer(at: CGPoint(x: 1024, y: 0))
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let location = touch.location(in: self)
			let ball = SKSpriteNode(imageNamed: "ballRed")
			ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width * 0.5)
			ball.physicsBody?.restitution = 0.4
			ball.position = location
			addChild(ball)
		}
	}

	// MARK: - Helpers
	private func makeBouncer(at position: CGPoint) {
		let bouncer = SKSpriteNode(imageNamed: "bouncer")
		bouncer.position = position
		bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width * 0.5)
		bouncer.physicsBody?.isDynamic = false
		addChild(bouncer)
	}
}
